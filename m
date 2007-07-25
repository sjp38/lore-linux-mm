Received: by wa-out-1112.google.com with SMTP id m33so295422wag
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 10:15:49 -0700 (PDT)
Message-ID: <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
Date: Wed, 25 Jul 2007 13:15:49 -0400
From: "Robert Deaton" <false.hopes@gmail.com>
Subject: Re: howto get a patch merged (WAS: Re: -mm merge plans for 2.6.23)
In-Reply-To: <46A773EA.5030103@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	 <46A773EA.5030103@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Rene Herman <rene.herman@gmail.com> wrote:
> And there we go again -- off into blabber-land. Why does swap-prefetch help
> updatedb? Or doesn't it? And if it doesn't, why should anyone trust anything
> else someone who said it does says?

I don't think anyone has ever argued that swap-prefetch directly helps
the performance of updatedb in any way, however, I do recall people
mentioning that updatedb, being a ram intensive task, will often cause
things to be swapped out while it runs on say a nightly cronjob. If a
person is not at their computer, updatedb will run, cause all their
applications to be swapped out, finish its work, and exit, leaving all
the other applications that would have otherwise been left in RAM for
when the user returns to his/her computer in swap. Thus, when someone
returns, you have to wait for all your applications to be swapped back
in.

Swap prefetch, on the other hand, would have kicked in shortly after
updatedb finished, leaving the applications in swap for a speedy
recovery when the person comes back to their computer.

-- 
--Robert Deaton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
