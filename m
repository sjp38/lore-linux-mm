Date: Thu, 17 Aug 2006 09:34:28 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH] "challenged" memory controller
Message-Id: <20060817093428.8ae4ca70.pj@sgi.com>
In-Reply-To: <44E447E7.8070502@in.ibm.com>
References: <20060815192047.EE4A0960@localhost.localdomain>
	<20060815150721.21ff961e.pj@sgi.com>
	<44E447E7.8070502@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: dave@sr71.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir wrote:
> Would it be possible to protect task->cpuset using rcu_read_lock()

Perhaps.  It usually takes me a few days of energetic thinking to
provide reliable answers to such cpuset locking questions, so offhand
I really don't know.

Fortunately Dave assures us it doesn't matter.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
