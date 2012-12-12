Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 93B006B0083
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:48:08 -0500 (EST)
Message-ID: <50C8FB94.6050209@linux.intel.com>
Date: Wed, 12 Dec 2012 13:48:04 -0800
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 09/11] thp: lazy huge zero page allocation
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-10-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1211141535190.22537@chino.kir.corp.google.com> <20121115094155.GG9676@otc-wbsnb-06> <20121212133051.6dad3722.akpm@linux-foundation.org>
In-Reply-To: <20121212133051.6dad3722.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On 12/12/2012 01:30 PM, Andrew Morton wrote:
>>
>> I can rewrite the check to static_key if you want. Would it be better?
> 
> The new test-n-branch only happens on the first read fault against a
> thp huge page, yes?  In which case it's a quite infrequent event and I
> suspect this isn't worth bothering about.
> 

Not to mention that flipping the static key is *incredibly* expensive.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
