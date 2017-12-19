Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6436B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:35:26 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f9so15511665qtf.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 13:35:26 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id i187si11747571qkf.270.2017.12.19.13.35.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 13:35:24 -0800 (PST)
Message-ID: <1513719296.2743.12.camel@kernel.crashing.org>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 20 Dec 2017 08:34:56 +1100
In-Reply-To: <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
	 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
	 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
	 <20171218221850.GD5461@ram.oc3035372033.ibm.com>
	 <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Mon, 2017-12-18 at 14:28 -0800, Dave Hansen wrote:
> > We do not have generic support for something like that on ppc.
> > The kernel looks at the device tree to determine what hardware features
> > are available. But does not have mechanism to tell the hardware to track
> > which of its features are currently enabled/used by the kernel; atleast
> > not for the memory-key feature.
> 
> Bummer.  You're missing out.
> 
> But, you could still do this with a syscall.  "Hey, kernel, do you
> support this feature?"

I'm not sure I understand Ram's original (quoted) point, but informing
userspace of CPU features is what AT_HWCAP's are about.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
