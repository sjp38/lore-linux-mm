Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 503636B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 09:46:25 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j2so4208746qtl.1
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 06:46:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w6si62903qtc.196.2018.03.19.06.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 06:46:24 -0700 (PDT)
Date: Mon, 19 Mar 2018 14:46:18 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
Message-ID: <20180319134618.GB12554@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180314165943.GA5948@redhat.com>
 <9cb068f7-0996-6e24-a95b-771006559318@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9cb068f7-0996-6e24-a95b-771006559318@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On 03/19, Ravi Bangoria wrote:
>
> Hi Oleg,
> 
> On 03/14/2018 10:29 PM, Oleg Nesterov wrote:
> > On 03/13, Ravi Bangoria wrote:
> >> +static bool sdt_valid_vma(struct trace_uprobe *tu, struct vm_area_struct *vma)
> >> +{
> >> +	unsigned long vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> >> +
> >> +	return tu->ref_ctr_offset &&
> >> +		vma->vm_file &&
> >> +		file_inode(vma->vm_file) == tu->inode &&
> >> +		vma->vm_flags & VM_WRITE &&
> >> +		vma->vm_start <= vaddr &&
> >> +		vma->vm_end > vaddr;
> >> +}
> > Perhaps in this case a simple
> >
> > 		ref_ctr_offset < vma->vm_end - vma->vm_start
> >
> > check without vma_offset_to_vaddr() makes more sense, but I won't insist.
> >
> 
> I still don't get this. This seems a comparison between file offset and size
> of the vma. Shouldn't we need to consider pg_off here?

Indeed, I am stupid ;)

Oleg.
