Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A95BA6B007D
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 19:26:07 -0500 (EST)
Date: Wed, 4 Nov 2009 18:49:23 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [MM] Make mm counters per cpu instead of atomic
Message-ID: <20091104234923.GA25306@redhat.com>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 02:14:41PM -0500, Christoph Lameter wrote:
 
 > +		memset(m, sizeof(struct mm_counter), 0);

Args wrong way around.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
