Date: Fri, 05 Apr 2002 10:47:28 -0800
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: 2.2.20 suspends everything then recovers during heavy I/O
Message-ID: <1648866003.1018003647@[10.10.2.3]>
In-Reply-To: <20020405182738.19092.qmail@london.rubylane.com>
References: <20020405182738.19092.qmail@london.rubylane.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jim@rubylane.com, Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> What would be really great is some way to indicate, maybe with an
> O_SEQ flag or something, that an application is going to sequentially
> access a file, so cacheing it is a no-win proposition.  Production
> servers do have situations where lots of data has to be copied or
> accessed, for example, to do a backup, but doing a backup shouldn't
> mean that all of the important stuff gets continuously thrown out of
> memory while the backup is running.  Saving metadata during a backup
> is useful.  Saving file data isn't.  It's seems hard to do this
> without an application hint because I may scan a database
> sequentially but I'd still want those buffers to stay resident.

Doesn't the raw IO stuff do this, effectively?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
