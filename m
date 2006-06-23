Date: Fri, 23 Jun 2006 12:40:32 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: linux-mm remailer eats [PATCH xx/yy] subject lines?
Message-Id: <20060623124032.5fdf6a2c.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606231207310.7483@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606221141450.30988@schroedinger.engr.sgi.com>
	<20060623185828.GB13617@kvack.org>
	<Pine.LNX.4.64.0606231159310.7339@schroedinger.engr.sgi.com>
	<20060623190555.GA14126@kvack.org>
	<Pine.LNX.4.64.0606231207310.7483@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: bcrl@kvack.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Paul, could sendpatchset prevent this [two subj/from headers]?

I don't think sendpatchset can prevent this.

I can't reproduce the problem, and I am guessing that the merged
headers occurred further down the email chain than sendpatchset.

I just used sendpatchset to send myself a message that had Subject:
and From: lines in the first two lines of the message.  I received
the message with those two lines still correctly in the body (after
the blank line that ends the email headers).

If someone else knows how to reproduce this problem, then we'll have
to debug it from there.

I rather doubt that its sendpatchset that is doing this.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
