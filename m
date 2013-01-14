Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 861F36B0068
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 17:03:42 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so2009621dam.32
        for <linux-mm@kvack.org>; Mon, 14 Jan 2013 14:03:41 -0800 (PST)
Message-ID: <50F480BB.6070105@gmail.com>
Date: Mon, 14 Jan 2013 14:03:39 -0800
From: David Daney <ddaney.cavm@gmail.com>
MIME-Version: 1.0
Subject: Re: 3.8-rc1 build failure with MIPS/SPARSEMEM
References: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi> <20121226003434.GA27760@otc-wbsnb-06> <20121227121607.GA7097@blackmetal.musicnaut.iki.fi> <20121230103850.GA5424@otc-wbsnb-06> <20130114151641.GA17996@otc-wbsnb-06>
In-Reply-To: <20130114151641.GA17996@otc-wbsnb-06>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, Aaro Koskinen <aaro.koskinen@iki.fi>

On 01/14/2013 07:16 AM, Kirill A. Shutemov wrote:
> On Sun, Dec 30, 2012 at 12:38:50PM +0200, Kirill A. Shutemov wrote:
>> On Thu, Dec 27, 2012 at 02:16:07PM +0200, Aaro Koskinen wrote:
>>> Hi,
>>>
>>> On Wed, Dec 26, 2012 at 02:34:35AM +0200, Kirill A. Shutemov wrote:
>>>> On MIPS if SPARSEMEM is enabled we've got this:
>>>>
>>>> In file included from /home/kas/git/public/linux/arch/mips/include/asm/pgtable.h:552,
>>>>                   from include/linux/mm.h:44,
>>>>                   from arch/mips/kernel/asm-offsets.c:14:
>>>> include/asm-generic/pgtable.h: In function a??my_zero_pfna??:
>>>> include/asm-generic/pgtable.h:466: error: implicit declaration of function a??page_to_sectiona??
>>>> In file included from arch/mips/kernel/asm-offsets.c:14:
>>>> include/linux/mm.h: At top level:
>>>> include/linux/mm.h:738: error: conflicting types for a??page_to_sectiona??
>>>> include/asm-generic/pgtable.h:466: note: previous implicit declaration of a??page_to_sectiona?? was here
>>>>
>>>> Due header files inter-dependencies, the only way I see to fix it is
>>>> convert my_zero_pfn() for __HAVE_COLOR_ZERO_PAGE to macros.
>>>>
>>>> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>>>
>>> Thanks, this works.
>>>
>>> Tested-by: Aaro Koskinen <aaro.koskinen@iki.fi>
>>
>> Andrew, could you take the patch?

I found the same problem and arrived at an equivalent solution.

Acked-by: David Daney <david.daney@cavium.com>

>
> ping?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
