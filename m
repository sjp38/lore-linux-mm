Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DF19900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:44:45 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20110428224038.GG1696@quack.suse.cz>
References: <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <1303993705-sup-5213@think> <1303998140.2081.11.camel@lenovo>
	 <1303998300-sup-4941@think> <1303999282.2081.15.camel@lenovo>
	 <20110428142551.GD1696@quack.suse.cz> <20110428143329.GE1696@quack.suse.cz>
	 <1304002701.2081.21.camel@lenovo>  <20110428224038.GG1696@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 17:44:39 -0500
Message-ID: <1304030679.2598.43.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Colin Ian King <colin.king@ubuntu.com>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Fri, 2011-04-29 at 00:40 +0200, Jan Kara wrote:
> James in the meantime identified that cgroups are somehow involved.
> Are you
> using systemd by any chance? Maybe cgroup IO throttling screws us?

Yes, this is a FC15 system with systemd as the default.

See related post: it looks like disabling the memory controller is what
makes this go away.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
