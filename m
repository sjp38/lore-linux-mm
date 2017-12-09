Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7D206B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 07:31:36 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id t13so3476666lfe.2
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 04:31:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 67sor2021014ljj.15.2017.12.09.04.31.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Dec 2017 04:31:29 -0800 (PST)
Message-ID: <1512822686.4168.4.camel@gmail.com>
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Sat, 09 Dec 2017 17:31:26 +0500
In-Reply-To: <20171208040556.GG19219@magnolia>
References: <1512705038.7843.6.camel@gmail.com>
	 <20171208040556.GG19219@magnolia>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2017-12-07 at 20:05 -0800, Darrick J. Wong wrote:
> > Hi, can anybody said what here happens? And which info needed for
> > fixing it? Thanks. [16712.376081] INFO: task tracker-store:27121
> > blocked for more than 120 seconds. [16712.376088] Not tainted
> > 4.15.0-rc2-amd-vega+ #10 [16712.376092] "echo 0 >
> > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [16712.376095] tracker-store D13400 27121 1843 0x00000000
> > [16712.376102] Call Trace: [16712.376114] ? __schedule+0x2e3/0xb90
> > [16712.376123] ? wait_for_completion+0x146/0x1e0 [16712.376128]
> > schedule+0x2f/0x90 [16712.376132] schedule_timeout+0x236/0x540
> > [16712.376143] ? mark_held_locks+0x4e/0x80 [16712.376147] ?
> > _raw_spin_unlock_irq+0x29/0x40 [16712.376153] ?
> > wait_for_completion+0x146/0x1e0 [16712.376158]
> > wait_for_completion+0x16e/0x1e0 [16712.376162] ?
> > wake_up_q+0x70/0x70 [16712.376204] ? xfs_buf_read_map+0x134/0x2f0
> > [xfs] [16712.376234] xfs_buf_submit_wait+0xaf/0x520 [xfs]
> 
> 

Stuck waiting for a directory block to read. 
> Slow disk? 
Usual Seagate SATA3 HDD with 7200rpms

> Bad media?
No. If there were problems with the hard drive, we would see errors in
the logs.

Any way you can sure in this if look at smartctl output for HDD.

https://paste.fedoraproject.org/paste/EsELRXoiKzlkR5PYhVmJeg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
