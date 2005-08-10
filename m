Date: Wed, 10 Aug 2005 13:27:44 -0700 (PDT)
Message-Id: <20050810.132744.18577541.davem@davemloft.net>
Subject: Re: [PATCH/RFT 2/5] CLOCK-Pro page replacement
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050810200943.068937000@jumble.boston.redhat.com>
References: <20050810200216.644997000@jumble.boston.redhat.com>
	<20050810200943.068937000@jumble.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Rik van Riel <riel@redhat.com>
Date: Wed, 10 Aug 2005 16:02:18 -0400
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> --- linux-2.6.12-vm.orig/fs/proc/proc_misc.c
> +++ linux-2.6.12-vm/fs/proc/proc_misc.c
> @@ -219,6 +219,20 @@ static struct file_operations fragmentat
>  	.release	= seq_release,
>  };
>  
> +extern struct seq_operations refaults_op;

Please put this in linux/mm.h or similar, so that we'll get proper
type checking of the definition in nonresident.c

Otherwise looks great.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
