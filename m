Received: from harpo.inetint.com (harpo [172.16.99.60])
	by ns-inetext.inet.com (8.9.2/8.9.2) with ESMTP id RAA07095
	for <linux-mm@kvack.org>; Wed, 21 Mar 2001 17:11:39 -0600 (CST)
Message-ID: <3AB9352A.71E42C38@inet.com>
Date: Wed, 21 Mar 2001 17:11:38 -0600
From: Eli Carter <eli.carter@inet.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <3AB9313C.1020909@missioncriticallinux.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Patrick O'Rourke <orourke@missioncriticallinux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Patrick O'Rourke wrote:
> 
> Since the system will panic if the init process is chosen by
> the OOM killer, the following patch prevents select_bad_process()
> from picking init.
> 
> Pat
> 
> --- xxx/linux-2.4.3-pre6/mm/oom_kill.c  Tue Nov 14 13:56:46 2000
> +++ linux-2.4.3-pre6/mm/oom_kill.c      Wed Mar 21 15:25:03 2001
> @@ -123,7 +123,7 @@
> 
>          read_lock(&tasklist_lock);
>          for_each_task(p) {
> -               if (p->pid) {
> +               if (p->pid && p->pid != 1) {
>                          int points = badness(p);
>                          if (points > maxpoints) {
>                                  chosen = p;
> 

Having not looked at the code... Why not "if( p->pid > 1 )"?  (Or can
p->pid can be negative?!, um, typecast to unsigned...)

Eli
-----------------------.           Rule of Accuracy: When working toward
Eli Carter             |            the solution of a problem, it always 
eli.carter(at)inet.com `------------------ helps if you know the answer.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
