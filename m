Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
 restart
From: Joe Perches <joe@perches.com>
In-Reply-To: <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	 <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain
Date: Fri, 05 Dec 2008 23:26:06 -0800
Message-Id: <1228548366.13046.614.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linux Torvalds <torvalds@osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, MinChan Kim <minchan.kim@gmail.com>, arnd@arndb.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-05 at 12:31 -0500, Oren Laadan wrote:
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> new file mode 100644
> index 0000000..63f298f
> --- /dev/null
> +++ b/include/linux/checkpoint.h
[]
> +#define cr_debug(fmt, args...)  \
> +	pr_debug("[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__, ## args)
> +

perhaps:

#define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__

and use pr_debug instead?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
