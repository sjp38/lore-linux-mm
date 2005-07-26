Date: Tue, 26 Jul 2005 14:12:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Memory pressure handling with iSCSI
Message-Id: <20050726141215.691379a2.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.61.0507261659250.1786@chimarrao.boston.redhat.com>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	<Pine.LNX.4.61.0507261659250.1786@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: pbadari@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:
>
> On Tue, 26 Jul 2005, Badari Pulavarty wrote:
> 
> > After KS & OLS discussions about memory pressure, I wanted to re-do
> > iSCSI testing with "dd"s to see if we are throttling writes.  
> 
> Could you also try with shared writable mmap, to see if that
> works ok or triggers a deadlock ?
> 

That'll cause problems for sure, but we need to get `dd' right first :(
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
