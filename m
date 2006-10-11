Subject: Re: RSS accounting (was: Re: 2.6.19-rc1-mm1)
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <m11wpfohg7.fsf@ebiederm.dsl.xmission.com>
References: <20061010000928.9d2d519a.akpm@osdl.org>
	 <1160464800.3000.264.camel@laptopd505.fenrus.org>
	 <20061010004526.c7088e79.akpm@osdl.org>
	 <1160467401.3000.276.camel@laptopd505.fenrus.org>
	 <1160486087.25613.52.camel@taijtu>
	 <1160496790.3000.319.camel@laptopd505.fenrus.org>
	 <m11wpfohg7.fsf@ebiederm.dsl.xmission.com>
Content-Type: text/plain
Date: Wed, 11 Oct 2006 10:47:42 +0200
Message-Id: <1160556462.3000.359.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 17:54 -0600, Eric W. Biederman wrote:

> For processes shared pages are not special.

depends on what question you want to answer with RSS.
If the question is "workload working set size" then you are right. If
the question is "how much ram does my application cause to be used" the
answer is FAR less clear....

You seem to have an implicit definition on what RSS should mean; but
it's implicit. Mind making an explicit definition of what RSS should be
in your opinion? I think that's the biggest problem we have right now;
several people have different ideas about what it should/could be, and
as such we're not talking about the same thing. Lets first agree/specify
what it SHOULD mean, and then we can figure out what gets counted for
that ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
