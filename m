Date: Wed, 11 Apr 2007 02:53:05 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
Message-Id: <20070411025305.b9131062.pj@sgi.com>
In-Reply-To: <ac8af0be0704110214qdca2ee9t3b44a17341e53730@mail.gmail.com>
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	<84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
	<ac8af0be0704110214qdca2ee9t3b44a17341e53730@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'm confused - which end of ths stack is up?

cpuset_exit doesn't call do_exit, rather it's the other
way around.  But put_files_struct doesn't call do_exit,
rather do_exit calls __exit_files calls put_files_struct.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
