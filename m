Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 96B5E6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 20:00:06 -0400 (EDT)
Received: by wyf23 with SMTP id 23so1453514wyf.14
        for <linux-mm@kvack.org>; Fri, 22 Oct 2010 17:00:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1287774180.23017.228.camel@bobble.smo.corp.google.com>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
	<1287774180.23017.228.camel@bobble.smo.corp.google.com>
Date: Sat, 23 Oct 2010 08:00:04 +0800
Message-ID: <AANLkTi=Pm34F7-ydwzzgsKZKNGCemFRnMj_e740+sdTF@mail.gmail.com>
Subject: Re: VFS scaling evaluation results, redux.
From: Lin Ming <lin@ming.vg>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Frank Mayhar <fmayhar@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, ext4-team@google.com
List-ID: <linux-mm.kvack.org>

On Sat, Oct 23, 2010 at 3:03 AM, Frank Mayhar <fmayhar@google.com> wrote:
> After seeing the newer work a couple of weeks ago, I decided to rerun
> the tests against Dave Chinner's tree just to see how things fare with
> his changes. =A0This time I only ran the "socket test" due to time
> constraints and since the "storage test" didn't produce anything
> particularly interesting last time.

Could you share your "socket test" test case?
I'd like to test these vfs scaling patches also.

Thanks,
Lin Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
