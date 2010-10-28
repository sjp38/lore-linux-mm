Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EAE738D000B
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 05:34:57 -0400 (EDT)
Message-ID: <4CC943BE.5080607@kernel.org>
Date: Thu, 28 Oct 2010 12:34:54 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: 2.6.36 io bring the system to its knees
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com> <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com> <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com> <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com> <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com> <20101028090002.GA12446@elte.hu>
In-Reply-To: <20101028090002.GA12446@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/28/10 12:00 PM, Ingo Molnar wrote:
> * Pekka Enberg<penberg@kernel.org>  wrote:
>
>> On Thu, Oct 28, 2010 at 9:09 AM, Aidar Kultayev<the.aidar@gmail.com>  wrote:
>>> Find attached screenshot ( latencytop_n_powertop.png ) which depicts
>>> artifacts where the window manager froze at the time I was trying to
>>> see a tab in Konsole where the powertop was running.
>> You seem to have forgotten to include the attachment.
> I got it - it appears it was too large for lkml's ~500K mail size limit.
>
> Aidar, mind sending a smaller image?

Ingo, didn't you have some nice script to capture system state? Maybe 
that could shed some light to what's going on in Aidar's system?

             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
