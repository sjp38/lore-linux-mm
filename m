From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v5] remove no longer use of pdflush interface
Date: Wed, 13 Jun 2012 06:18:00 +0000 (UTC)
Message-ID: <jr9ban$4mi$1@dough.gmane.org>
References: <1339374670-2821-1-git-send-email-liwp.linux@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Mon, 11 Jun 2012 at 00:31 GMT, Wanpeng Li <liwp.linux@gmail.com> wrote:
> +	printk_once(KERN_WARNING "%s exported in /proc is scheduled for removal\n",
> +			table->procname);
> +

This equals to WARN_ONCE(1, ....);

