Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E25B66B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:45:20 -0500 (EST)
Received: by pff63 with SMTP id 63so17146077pff.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:45:20 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id ym10si11041441pab.146.2015.12.14.12.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 12:45:20 -0800 (PST)
Received: by pfnn128 with SMTP id n128so111338722pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:45:20 -0800 (PST)
Subject: Re: [PATCH v6 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
 <1449856338-30984-2-git-send-email-dcashman@android.com>
 <1449856338-30984-3-git-send-email-dcashman@android.com>
 <1449856338-30984-4-git-send-email-dcashman@android.com>
 <20151214111949.GD6992@arm.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <566F2A5D.6010100@android.com>
Date: Mon, 14 Dec 2015 12:45:17 -0800
MIME-Version: 1.0
In-Reply-To: <20151214111949.GD6992@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com

On 12/14/2015 03:19 AM, Will Deacon wrote:
>> +# max bits determined by the following formula:
>> +#  VA_BITS - PAGE_SHIFT - 3
> 
> Now that we have this comment, I think we can drop the unsupported
> combinations from the list below. That means we just end up with:
> 
>> +config ARCH_MMAP_RND_BITS_MAX
>> +       default 19 if ARM64_VA_BITS=36
>> +       default 24 if ARM64_VA_BITS=39
>> +       default 27 if ARM64_VA_BITS=42
>> +       default 30 if ARM64_VA_BITS=47
>> +       default 29 if ARM64_VA_BITS=48 && ARM64_64K_PAGES
>> +       default 31 if ARM64_VA_BITS=48 && ARM64_16K_PAGES
>> +       default 33 if ARM64_VA_BITS=48

Unless you object, I'd like to keep the last 3 as well, to mirror the
min bits, should any new configurations be added but not reflected here:
+       default 15 if ARM64_64K_PAGES
+       default 17 if ARM64_16K_PAGES
+       default 18

The first two of these three should be changed as well to 14 and 16.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
