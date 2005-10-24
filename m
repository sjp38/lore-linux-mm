Date: Sun, 23 Oct 2005 23:32:37 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] cpuset confine pdflush to its cpuset
Message-Id: <20051023233237.0982b54b.pj@sgi.com>
In-Reply-To: <20051024.145258.98349934.taka@valinux.co.jp>
References: <20051024001913.7030.71597.sendpatchset@jackhammer.engr.sgi.com>
	<20051024.145258.98349934.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: akpm@osdl.org, Simon.Derr@bull.net, linux-kernel@vger.kernel.org, clameter@sgi.com, torvalds@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Takahashi-san wrote:
> I realized CPUSETS has another problem around pdflush.

Excellent observation.  I had not realized this.

Thank-you for pointing it out.

I don't have plans.  Do you have any suggestions?

  ( Anyone know what the "pd" stands for in pdflush ?? )

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
