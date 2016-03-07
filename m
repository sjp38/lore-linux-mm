Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAEF6B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 12:36:01 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id tt10so20093909pab.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 09:36:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sm10si6912625pab.78.2016.03.07.09.36.00
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 09:36:00 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56DDBBFD.8040106@intel.com>
Date: Mon, 7 Mar 2016 09:35:57 -0800
MIME-Version: 1.0
In-Reply-To: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org
Cc: rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/02/2016 12:39 PM, Khalid Aziz wrote:
> +long enable_sparc_adi(unsigned long addr, unsigned long len)
> +{
> +	unsigned long end, pagemask;
> +	int error;
> +	struct vm_area_struct *vma, *vma2;
> +	struct mm_struct *mm;
> +
> +	if (!ADI_CAPABLE())
> +		return -EINVAL;
...

This whole thing with the VMA splitting and so forth looks pretty darn
arch-independent.  Are you sure you need that much arch-specific code
for it, or can you share more of the generic VMA management code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
