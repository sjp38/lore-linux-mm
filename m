Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC6106B026B
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:22:33 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c190so13606051qkb.12
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:22:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n133si128454qkn.139.2017.12.19.08.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 08:22:33 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBJGKBXL047116
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:22:32 -0500
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ey46pyedb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:22:32 -0500
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 19 Dec 2017 11:22:31 -0500
Date: Tue, 19 Dec 2017 08:22:21 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
 <20171218221850.GD5461@ram.oc3035372033.ibm.com>
 <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
 <20171218231551.GA5481@ram.oc3035372033.ibm.com>
 <20171219083122.q7ycxg2dfspgzw7z@lt-gp.iram.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219083122.q7ycxg2dfspgzw7z@lt-gp.iram.es>
Message-Id: <20171219162221.GB5481@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gabriel Paubert <paubert@iram.es>
Cc: linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, mingo@redhat.com, paulus@samba.org, ebiederm@xmission.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Tue, Dec 19, 2017 at 09:31:22AM +0100, Gabriel Paubert wrote:
> On Mon, Dec 18, 2017 at 03:15:51PM -0800, Ram Pai wrote:
> > On Mon, Dec 18, 2017 at 02:28:14PM -0800, Dave Hansen wrote:
> > > On 12/18/2017 02:18 PM, Ram Pai wrote:
> > > 
....snip...
> > > > I think on x86 you look for some hardware registers to determine
> > > > which hardware features are enabled by the kernel.
> > > 
> > > No, we use CPUID.  It's a part of the ISA that's designed for
> > > enumerating CPU and (sometimes) OS support for CPU features.
> > > 
> > > > We do not have generic support for something like that on ppc.  The
> > > > kernel looks at the device tree to determine what hardware features
> > > > are available. But does not have mechanism to tell the hardware to
> > > > track which of its features are currently enabled/used by the
> > > > kernel; atleast not for the memory-key feature.
> > > 
> > > Bummer.  You're missing out.
> > > 
> > > But, you could still do this with a syscall.  "Hey, kernel, do you
> > > support this feature?"
> > 
> > or do powerpc specific sysfs interface.
> > or a debugfs interface.
> 
> getauxval(3) ?
> 
> With AT_HWCAP or HWCAP2 as parameter already gives information about
> features supported by the hardware and the kernel.
> 
> Taking one bit to expose the availability of protection keys to
> applications does not look impossible.
> 
> Do I miss something obvious?

No. I am told this is possible aswell.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
