Date: Fri, 27 Jul 2007 12:19:30 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070727121930.30779cad.pj@sgi.com>
In-Reply-To: <20070726102025.GJ27237@ftp.linux.org.uk>
References: <46A57068.3070701@yahoo.com.au>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
	<p73abtkrz37.fsf@bingen.suse.de>
	<46A85D95.509@kingswood-consulting.co.uk>
	<20070726092025.GA9157@elte.hu>
	<20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	<20070726094024.GA15583@elte.hu>
	<20070726102025.GJ27237@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: mingo@elte.hu, akpm@linux-foundation.org, frank@kingswood-consulting.co.uk, andi@firstfloor.org, nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, jesper.juhl@gmail.com, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Al Viro wrote:
> BTW, I really wonder how much pain could be avoided if updatedb recorded
> mtime of directories and checked it.

Someone mentioned a variant of slocate above that they called mlocate,
and that Red Hat ships, that seems to do this (if I understand you and
what mlocate does correctly.)

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
