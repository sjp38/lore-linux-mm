Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 379246B0080
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:27:35 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so32394vcb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 01:27:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326788038-29141-2-git-send-email-minchan@kernel.org>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
Date: Tue, 17 Jan 2012 11:27:34 +0200
Message-ID: <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Jan 17, 2012 at 10:13 AM, Minchan Kim <minchan@kernel.org> wrote:
> +static unsigned int low_mem_notify_poll(struct file *file, poll_table *w=
ait)
> +{
> + =A0 =A0 =A0 =A0unsigned int ret =3D 0;
> +
> + =A0 =A0 =A0 =A0poll_wait(file, &low_mem_wait, wait);
> +
> + =A0 =A0 =A0 =A0if (atomic_read(&nr_low_mem) !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D POLLIN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_set(&nr_low_mem, 0);
> + =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 =A0return ret;
> +}

Doesn't this mean that only one application will receive the notification?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
