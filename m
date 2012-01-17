Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 57A3C6B004F
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 14:57:54 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so2541025vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 11:57:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLFzuvYm2pHZP--=nx3qGatzgfT6Dii49gzJwzxOtzniTg@mail.gmail.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<4F15CC56.90309@redhat.com>
	<CAOJsxLFzuvYm2pHZP--=nx3qGatzgfT6Dii49gzJwzxOtzniTg@mail.gmail.com>
Date: Tue, 17 Jan 2012 21:57:53 +0200
Message-ID: <CAOJsxLFQdOCz2dSzNHhFXjoSuCPfH+eSgzHM5KuVMuM=fmJMQA@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Jan 17, 2012 at 9:49 PM, Pekka Enberg <penberg@kernel.org> wrote:
>> The desire to avoid such wakeups makes it harder to
>> wake up processes at arbitrary points set by the API.
>
> Sure. You could either bump up the threshold or use Minchan's hooks - or both.

s/threshold/sample period/g

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
