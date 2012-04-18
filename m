Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 6DBA46B00ED
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:52:43 -0400 (EDT)
Message-ID: <4F8EE35A.3060200@redhat.com>
Date: Wed, 18 Apr 2012 11:52:58 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: bug for stack ?
References: <op.wcwj76p5n27o5l@gaoqiang-d1.corp.qihoo.net>
In-Reply-To: <op.wcwj76p5n27o5l@gaoqiang-d1.corp.qihoo.net>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaoqiang <gaoqiangscut@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/17/2012 05:20 AM, gaoqiang wrote:
>
> memory allocated for process stack seems never to be freed by the kernel..

It should get freed on process exit.

> on a vmware machine with about 768m memory, run the following program.when
> printing "run over", run another case of the following program. oom-killer
> trigered, which is not so reasonable.

You start your second run before your first run
has exited.  The system does not have enough
memory for two such runs, so you run out of
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
