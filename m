Received: by xproxy.gmail.com with SMTP id s11so59197wxc
        for <linux-mm@kvack.org>; Tue, 07 Mar 2006 18:52:05 -0800 (PST)
Message-ID: <b8bf37780603071852r6bf3821fr7610597a54ad305b@mail.gmail.com>
Date: Tue, 7 Mar 2006 22:52:05 -0400
From: "=?ISO-8859-1?Q?Andr=E9_Goddard_Rosa?=" <andre.goddard@gmail.com>
Subject: Re: [ck] Re: [PATCH] mm: yield during swap prefetching
In-Reply-To: <200603081330.56548.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <200603081013.44678.kernel@kolivas.org>
	 <200603081322.02306.kernel@kolivas.org>
	 <1141784834.767.134.camel@mindpipe>
	 <200603081330.56548.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Lee Revell <rlrevell@joe-job.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

[...]
> > > Because being a serious desktop operating system that we are
> > > (bwahahahaha) means the user should not have special privileges to run
> > > something as simple as a game. Games should not need special scheduling
> > > classes. We can always use 'nice' for a compile though. Real time audio
> > > is a completely different world to this.
[...]
> Well as I said in my previous reply, games should _not_ need special
> scheduling classes. They are not written in a real time smart way and they do
> not have any realtime constraints or requirements.

Sorry Con, but I have to disagree with you on this.

Games are very complex software, involving heavy use of hardware resources
and they also have a lot of time constraints. So, I think they should
use RT priorities
if it is necessary to get the resources needed in time.

Thanks,
--
[]s,

Andre Goddard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
