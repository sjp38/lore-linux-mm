Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE5986810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:09:19 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id y70so2009003vky.13
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:09:19 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 15si22298vkg.151.2017.07.11.15.09.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 15:09:17 -0700 (PDT)
Message-ID: <1499810936.2865.32.camel@kernel.crashing.org>
Subject: Re: [RFC v5 12/38] mm: ability to disable execute permission on a
 key at creation
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 12 Jul 2017 08:08:56 +1000
In-Reply-To: <20170711215105.GA5542@ram.oc3035372033.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
	 <1499289735-14220-13-git-send-email-linuxram@us.ibm.com>
	 <3bd2ffd4-33ad-ce23-3db1-d1292e69ca9b@intel.com>
	 <1499808577.2865.30.camel@kernel.crashing.org>
	 <20170711215105.GA5542@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com

On Tue, 2017-07-11 at 14:51 -0700, Ram Pai wrote:
> On Wed, Jul 12, 2017 at 07:29:37AM +1000, Benjamin Herrenschmidt wrote:
> > On Tue, 2017-07-11 at 11:11 -0700, Dave Hansen wrote:
> > > On 07/05/2017 02:21 PM, Ram Pai wrote:
> > > > Currently sys_pkey_create() provides the ability to disable read
> > > > and write permission on the key, at  creation. powerpc  has  the
> > > > hardware support to disable execute on a pkey as well.This patch
> > > > enhances the interface to let disable execute  at  key  creation
> > > > time. x86 does  not  allow  this.  Hence the next patch will add
> > > > ability  in  x86  to  return  error  if  PKEY_DISABLE_EXECUTE is
> > > > specified.
> > 
> > That leads to the question... How do you tell userspace.
> > 
> > (apologies if I missed that in an existing patch in the series)
> > 
> > How do we inform userspace of the key capabilities ? There are at least
> > two things userspace may want to know already:
> > 
> >  - What protection bits are supported for a key
> 
> the userspace is the one which allocates the keys and enables/disables the
> protection bits on the key. the kernel is just a facilitator. Now if the
> use space wants to know the current permissions on a given key, it can
> just read the AMR/PKRU register on powerpc/intel respectively.

You misunderstand. How does userspace knows on a given system whether
execute permission control is supported for keys ?
> 
> > 
> >  - How many keys exist
> 
> There is no standard way of finding this other than trying to allocate
> as many till you fail.  A procfs or sysfs file can be added to expose
> this information.
> 
> > 
> >  - Which keys are available for use by userspace. On PowerPC, the
> > kernel can reserve some keys for itself, so can the hypervisor. In
> > fact, they do.
> 
> this information can be exposed through /proc or /sysfs
> 
> I am sure there will be more demands and requirements as applications
> start leveraging these feature.
> 
> RP
> > 
> > Cheers,
> > Ben.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
