From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] mm: Warn about costly page allocation
Date: Mon, 9 Jul 2012 12:53:22 +0000 (UTC)
Message-ID: <jtek81$ja5$1@dough.gmane.org>
References: <1341801500-5798-1-git-send-email-minchan@kernel.org>
 <20120709082200.GX14154@suse.de> <20120709084657.GA7915@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Mon, 09 Jul 2012 at 08:46 GMT, Minchan Kim <minchan@kernel.org> wrote:
>> 
>> WARN_ON_ONCE would tell you what is trying to satisfy the allocation.
>
> Do you mean that it would be better to use WARN_ON_ONCE rather than raw printk?
> If so, I would like to insist raw printk because WARN_ON_ONCE could be disabled
> by !CONFIG_BUG.
> If I miss something, could you elaborate it more?
>

Raw printk could be disabled by !CONFIG_PRINTK too, and given that:

config PRINTK
        default y
        bool "Enable support for printk" if EXPERT
		    
config BUG
        bool "BUG() support" if EXPERT
        default y

they are both configurable only when ERPERT, so we don't need to
worry much. :)
