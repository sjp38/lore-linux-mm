Message-ID: <462673F1.7070808@google.com>
Date: Wed, 18 Apr 2007 12:39:29 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com> <46259945.8040504@google.com> <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com> <4625AD3C.8010709@google.com> <Pine.LNX.4.64.0704172236140.4205@schroedinger.engr.sgi.com> <4625B711.8060400@google.com> <Pine.LNX.4.64.0704181235090.7234@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704181235090.7234@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 17 Apr 2007, Ethan Solomita wrote:
>
>   
>>    While you're busy correcting me, look in swap_state.c at
>> __add_to_swap_cache(). Note how, when it inserts a page into
>> swapper_space.page_tree, it then does an __inc_zone_page_state(NR_FILE_PAGES).
>>     
>
> Correct. So a page is accounted for both as anonymous and a file pages. 
> That is surprising. So this patch should indeed work. Added some comments
> to clarify the situation.
>   

    Given that it's exactly what I suggested in my first post, clearly I 
second your patch.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
