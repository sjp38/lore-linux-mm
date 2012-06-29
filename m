Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9E4096B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:04:15 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Skaro-0000F0-8m
	for linux-mm@kvack.org; Fri, 29 Jun 2012 15:04:08 +0200
Received: from 117.57.110.131 ([117.57.110.131])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:04:08 +0200
Received: from xiyou.wangcong by 117.57.110.131 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:04:08 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Date: Fri, 29 Jun 2012 13:03:55 +0000 (UTC)
Message-ID: <jsk93p$32e$1@dough.gmane.org>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Fri, 29 Jun 2012 at 11:49 GMT, Petr Holasek <pholasek@redhat.com> wrote:
> -		root_unstable_tree = RB_ROOT;
> +		for (i = 0; i < MAX_NUMNODES; i++)
> +			root_unstable_tree[i] = RB_ROOT;


This is not aware of memory-hotplug, right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
