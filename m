Message-ID: <27525795B28BD311B28D00500481B7601F1065@ftrs1.intranet.ftr.nl>
From: "Heusden, Folkert van" <f.v.heusden@ftr.nl>
Subject: RE: [PATCH] Prevent OOM from killing init
Date: Thu, 22 Mar 2001 12:08:25 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Since the system will panic if the init process is chosen by
> the OOM killer, the following patch prevents select_bad_process()
> from picking init.

Hmmm, wouldn't it be nice to make this all configurable? Like; have
some list of PIDs that can be killed?
I would hate it the daemon that checks my UPS would get killed...
(that deamon brings the machine down safely when the UPS'
batteries get emptied).
Would be something like:

int *dont_kill_pid, ndont_kill_pid;
// initialize with at least pid '1' and n=1

         for_each_task(p) {
		int loop;
		for(loop=ndont_kill_pid-1; loop>=0; loop--)
		{
			if (dont_kill_pid[loop] == p->pid) break;
		}
              if (p->pid && !(loop>=0)) {
                         int points = badness(p);
                         if (points > maxpoints) {
                                 chosen = p;


(untested (not even compiled or anything) code)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
