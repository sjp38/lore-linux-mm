Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A76086B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 02:25:40 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <986278020.2030861285581319128.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Date: Mon, 27 Sep 2010 23:25:33 -0700
In-Reply-To: <986278020.2030861285581319128.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	(caiqian@redhat.com's message of "Mon, 27 Sep 2010 05:55:19 -0400
	(EDT)")
Message-ID: <m1vd5qo04i.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 0/3] Generic support for revoking mappings
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
List-ID: <linux-mm.kvack.org>

caiqian@redhat.com writes:

> ----- caiqian@redhat.com wrote:
>
>> ----- "Am=C3=A9rico Wang" <xiyou.wangcong@gmail.com> wrote:
>>=20
>> > On Mon, Sep 27, 2010 at 04:52:29AM -0400, CAI Qian wrote:
>> > >Just a head up. Tried to boot latest mmotm kernel with those
>> patches
>> > applied hit this. I am wondering what I did wrong.
> The only tricky part of the merge I can tell was for Andrea's commit,

Ok.  This is down right bizarre.
I have it running with the same merge resolution and I'm not seeing
any problems yet.

I will probe deeper tomorrow.  Are you certain you compiled things
properly?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
