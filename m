Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA22058
	for <linux-mm@kvack.org>; Mon, 23 Sep 2002 09:33:20 -0700 (PDT)
Message-ID: <3D8F4139.6BB60A35@digeo.com>
Date: Mon, 23 Sep 2002 09:28:41 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.38-mm2 [PATCH]
References: <3D8E96AA.C2FA7D8@digeo.com> <20020923151559.B29900@in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dipankar@in.ibm.com
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dipankar Sarma wrote:
> 
> ...
> -#ifdef CONFIG_PREEMPTION
> +#ifdef CONFIG_PREEMPT
>  #define rcu_read_lock()                preempt_disable()
>  #define rcu_read_unlock()      preempt_enable()
>  #else

Thanks.  I just replaced

#ifdef CONFIG_PREEMPTION
#define rcu_read_lock()        preempt_disable()
#define rcu_read_unlock()      preempt_enable()
#else
#define rcu_read_lock()        do {} while(0)
#define rcu_read_unlock()      do {} while(0)
#endif

with

#define rcu_read_lock()        preempt_disable()
#define rcu_read_unlock()      preempt_enable()

because preempt_disable() is a no-op on CONFIG_PREEMPT=n anyway.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
