Date: Fri, 29 Feb 2008 09:36:22 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: trivial clean up to zlc_setup
Message-Id: <20080229093622.2dfb6524.pj@sgi.com>
In-Reply-To: <20080229151057.66ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080229151057.66ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee.Schermerhorn@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

kosaki-san wrote:
> -       if (jiffies - zlc->last_full_zap > 1 * HZ) {
> +       if (time_after(jiffies, zlc->last_full_zap + HZ)) {

Nice catch.  Thank-you.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
