Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4658D0048
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:06:52 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p14I6nL9005398
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 10:06:49 -0800
Received: from qwe5 (qwe5.prod.google.com [10.241.194.5])
	by kpbe11.cbf.corp.google.com with ESMTP id p14I6KDl032028
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 10:06:47 -0800
Received: by qwe5 with SMTP id 5so2037217qwe.12
        for <linux-mm@kvack.org>; Fri, 04 Feb 2011 10:06:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110204164222.GG4104@quack.suse.cz>
References: <20110204164222.GG4104@quack.suse.cz>
Date: Fri, 4 Feb 2011 10:06:45 -0800
Message-ID: <AANLkTikUwWOrz_LF1nO=y9cE=Ndt_CUMH-HwH244z6n0@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Writeback - current state and future
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

I think it would also be valuable to include a discussion of writeback
testing, so perhaps we can go beyond simply large numbers of dd
processes.

On Fri, Feb 4, 2011 at 8:42 AM, Jan Kara <jack@suse.cz> wrote:
> =A0Hi,
>
> =A0I'd like to have one session about writeback. The content would highly
> depend on the current state of things but on a general level, I'd like to
> quickly sum up what went into the kernel (or is mostly ready to go) since
> last LSF (handling of background writeback, livelock avoidance), what is
> being worked on - IO-less balance_dirty_pages() (if it won't be in the
> mostly done section), what other things need to be improved (kswapd
> writeout, writeback_inodes_sb_if_idle() mess, come to my mind now)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
