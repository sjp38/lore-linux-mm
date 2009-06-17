Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DBA86B006A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:27:58 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C9C3182C4C0
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:45:04 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qegoGKXjBwnC for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 13:45:00 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2D62982C3FD
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:45:00 -0400 (EDT)
Date: Wed, 17 Jun 2009 12:57:37 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/9] percpu: cleanup percpu array definitions
In-Reply-To: <1245210060-24344-5-git-send-email-tj@kernel.org>
Message-ID: <alpine.DEB.1.10.0906171257130.1695@gentwo.org>
References: <1245210060-24344-1-git-send-email-tj@kernel.org> <1245210060-24344-5-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@elte.hu, kyle@mcmartin.ca, Jesper.Nilsson@axis.com, benh@kernel.crashing.org, paulmck@linux.vnet.ibm.com, Tony Luck <tony.luck@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Jeremy Fitzhardinge <jeremy@xensource.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>



Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
