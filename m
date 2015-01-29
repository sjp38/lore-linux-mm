Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 473A16B0072
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:22:34 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id x69so23088455oia.10
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:22:34 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id u11si3203714oib.67.2015.01.28.20.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 20:22:33 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YGgcj-00433p-4x
	for linux-mm@kvack.org; Thu, 29 Jan 2015 04:22:33 +0000
Message-ID: <54C9B584.6060302@roeck-us.net>
Date: Wed, 28 Jan 2015 20:22:28 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: split up mm_struct to separate header file
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com> <1422451064-109023-3-git-send-email-kirill.shutemov@linux.intel.com> <20150129003028.GA17519@node.dhcp.inet.fi>
In-Reply-To: <20150129003028.GA17519@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/28/2015 04:30 PM, Kirill A. Shutemov wrote:
> On Wed, Jan 28, 2015 at 03:17:42PM +0200, Kirill A. Shutemov wrote:
>> We want to use __PAGETABLE_PMD_FOLDED in mm_struct to drop nr_pmds if
>> pmd is folded. __PAGETABLE_PMD_FOLDED is defined in <asm/pgtable.h>, but
>> <asm/pgtable.h> itself wants <linux/mm_types.h> for struct page
>> definition.
>>
>> This patch move mm_struct definition into separate header file in order
>> to fix circular header dependencies.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
> Guenter, below is update for the patch. It doesn't fix all the issues, but
> you should see an improvement. I'll continue with this tomorrow.

Yes, this is much better than before.

Build results:
	total: 134 pass: 122 fail: 12
Failed builds:
	arm:imx_v6_v7_defconfig
	arm:s3c6400_defconfig
	cris:artpec_3_defconfig
	cris:etraxfs_defconfig
	hexagon:defconfig
	m68k:m5475evb_defconfig
	mips:allmodconfig
	s390:defconfig
	sparc64:defconfig
	sparc64:allmodconfig
	unicore32:defconfig
	xtensa:allmodconfig
Qemu tests:
	total: 30 pass: 28 fail: 2
Failed tests:
	sparc64:sparc_smp_defconfig
	sparc64:sparc_nosmp_defconfig

Some of the problems are inherited from mmotm.
Here are the mmotm build results (v3.19-rc6-462-g995c249):
	total: 134 pass: 128 fail: 6
Failed builds:
	arm:imx_v6_v7_defconfig
	arm:s3c6400_defconfig
	mips:allmodconfig
	sparc64:allmodconfig
	unicore32:defconfig
	xtensa:allmodconfig
Qemu tests:
	total: 30 pass: 30 fail: 0

With this, we can conclude that your patch series still has problems
(at least) with cris, hexagon, m68k, s390, sparc, and unicore32.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
