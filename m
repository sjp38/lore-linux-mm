Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F25456B00B3
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 07:16:13 -0400 (EDT)
Received: by ywl5 with SMTP id 5so581474ywl.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 04:16:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101028090002.GA12446@elte.hu>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
Date: Thu, 28 Oct 2010 14:16:11 +0300
Message-ID: <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Pekka Enberg <penberg@kernel.org> wrote:
>> On Thu, Oct 28, 2010 at 9:09 AM, Aidar Kultayev <the.aidar@gmail.com> wrote:
>> > Find attached screenshot ( latencytop_n_powertop.png ) which depicts
>> > artifacts where the window manager froze at the time I was trying to
>> > see a tab in Konsole where the powertop was running.
>>
>> You seem to have forgotten to include the attachment.

On Thu, Oct 28, 2010 at 12:00 PM, Ingo Molnar <mingo@elte.hu> wrote:
> I got it - it appears it was too large for lkml's ~500K mail size limit.
>
> Aidar, mind sending a smaller image?

Looks mostly VFS to me. Aidar, does killing Picasa make things
smoother for you? If so, maybe the VFS scalability patches will help.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
