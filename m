Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 16C136B025B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:05:09 -0500 (EST)
Received: by pfbg73 with SMTP id g73so33554385pfb.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:05:08 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id rn8si13736545pab.174.2015.12.09.09.05.08
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 09:05:08 -0800 (PST)
Subject: Re: [PATCH 26/34] mm: implement new mprotect_key() system call
References: <20151204011424.8A36E365@viggo.jf.intel.com>
 <20151204011500.69487A6C@viggo.jf.intel.com> <5662894B.7090903@gmail.com>
 <5665B767.8020802@sr71.net> <56680BA6.20406@gmail.com>
 <56684D3B.5050805@sr71.net>
 <CAKgNAkiZHny4amNcamN+q6pxdanG9aMMA4H_pekA7+RDuoUvEA@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56685F42.8070109@sr71.net>
Date: Wed, 9 Dec 2015 09:05:06 -0800
MIME-Version: 1.0
In-Reply-To: <CAKgNAkiZHny4amNcamN+q6pxdanG9aMMA4H_pekA7+RDuoUvEA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, dave.hansen@linux.intel.com, Linux API <linux-api@vger.kernel.org>

On 12/09/2015 08:45 AM, Michael Kerrisk (man-pages) wrote:
>>> >> * Explanation of what a protection domain is.
>> >
>> > A protection domain is a unique view of memory and is represented by the
>> > value in the PKRU register.
> Out something about this in pkey(7), but explain what you mean by a
> "unique view of memory".

Let's say there are only two protection keys: 0 and 1.  There are two
disable bits per protection key (Access and Write Disable), so a two-key
PKRU looks like:

|   PKEY0   |   PKEY1   |
| AD0 | WD0 | AD1 | WD1 |

In this example, there are 16 possible protection domains, one for each
possible combination of the 4 rights-disable bits.

"Changing a protection domain" would mean changing (setting or clearing)
the value of any of those 4 bits.  Each unique value of PKRU represents
a view of memory, or unique protection domain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
