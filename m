Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6DBA46B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 07:12:15 -0400 (EDT)
Message-ID: <1337080332.27694.39.camel@twins>
Subject: Re: [PATCH 0/2 v2] Flexible proportions for BDIs
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 15 May 2012 13:12:12 +0200
In-Reply-To: <20120514212803.GT5353@quack.suse.cz>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
	 <20120507144344.GA13983@localhost> <20120509113720.GC5092@quack.suse.cz>
	 <20120510073123.GA7523@localhost> <20120511145114.GA18227@localhost>
	 <20120513032952.GA8099@localhost> <20120514212803.GT5353@quack.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org

On Mon, 2012-05-14 at 23:28 +0200, Jan Kara wrote:
> So is anybody against merging this?

I'd like to see the timer disable itself stuff first.. other than that,
no.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
