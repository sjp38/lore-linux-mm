Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 346826B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 15:03:13 -0400 (EDT)
Message-ID: <4FDF7B5E.301@redhat.com>
Date: Mon, 18 Jun 2012 15:02:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 3/6] Fix the x86-64 page colouring code to take pgoff
 into account and use that code as the basis for a generic page colouring
 code.
References: <1340029878-7966-1-git-send-email-riel@redhat.com> <1340029878-7966-4-git-send-email-riel@redhat.com> <m2k3z48twb.fsf@firstfloor.org> <4FDF5B3C.1000007@redhat.com> <20120618181658.GA7190@x1.osrc.amd.com>
In-Reply-To: <20120618181658.GA7190@x1.osrc.amd.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, hnaz@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/18/2012 02:16 PM, Borislav Petkov wrote:
> On Mon, Jun 18, 2012 at 12:45:48PM -0400, Rik van Riel wrote:
>>> What tree is that against? I cannot find x86 page colouring code in next
>>> or mainline.
>>
>> This is against mainline.
>
> Which mainline do you mean exactly?
>
> 1/6 doesn't apply ontop of current mainline and by "current" I mean
> v3.5-rc3-57-g39a50b42f702.

After pulling in the latest patches, including that
39a50b... commit, all patches still apply here when
I type guilt push -a.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
