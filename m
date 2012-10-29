Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 0DDE36B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 12:24:33 -0400 (EDT)
Date: Mon, 29 Oct 2012 12:23:44 -0400
From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH v7 10/16] dlm: use new hashtable implementation
Message-ID: <20121029162344.GC3516@redhat.com>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-10-git-send-email-levinsasha928@gmail.com>
 <20121029124655.GD11733@Krystal>
 <20121029130736.GF11733@Krystal>
 <CA+1xoqfxgB+8BybPpf+jwT-ObfGPxnbKvkz1MUMuJuR8NDSNaw@mail.gmail.com>
 <20121029160710.GA18944@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029160710.GA18944@Krystal>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Mon, Oct 29, 2012 at 12:07:10PM -0400, Mathieu Desnoyers wrote:
> I'm fine with turning a direct + modulo mapping into a dispersed hash as
> long as there are no underlying assumptions about sequentiality of value
> accesses.
> 
> If the access pattern would happen to be typically sequential, then
> adding dispersion could hurt performances significantly, turning a
> frequent L1 access into a L2 access for instance.
  
> All I'm asking is: have you made sure that this hash table is not
> deliberately kept sequential (without dispersion) to accelerate specific
> access patterns ? This should at least be documented in the changelog.

It was not intentional.  I don't expect any benefit would be lost by
making it non-sequential.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
