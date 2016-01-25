Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id AEF7C6B0258
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:37:51 -0500 (EST)
Received: by mail-lf0-f42.google.com with SMTP id m198so88338434lfm.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:37:51 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id 185si10239039lfa.168.2016.01.25.08.37.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 08:37:49 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1aNk9C-0005Tx-7a
	for linux-mm@kvack.org; Mon, 25 Jan 2016 17:37:47 +0100
Received: from 65-125-35-19.newmexicoconsortium.org ([65-125-35-19.newmexicoconsortium.org])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 17:37:46 +0100
Received: from hugh by 65-125-35-19.newmexicoconsortium.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 17:37:46 +0100
From: Hugh Greenberg <hugh@galliumos.org>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Date: Mon, 25 Jan 2016 16:37:34 +0000 (UTC)
Message-ID: <loom.20160125T173426-535@post.gmane.org>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com> <20160121161656.GA16564@node.shutemov.name> <loom.20160123T165232-709@post.gmane.org> <20160125103853.GD11095@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Kirill A. Shutemov <kirill <at> shutemov.name> writes:

> 
> On Sat, Jan 23, 2016 at 03:57:21PM +0000, Hugh Greenberg wrote:
> > Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> > > 
> > > Could you try to insert 
"late_initcall(set_recommended_min_free_kbytes);"
> > > back and check if makes any difference.
> > > 
> > 
> > We tested adding late_initcall(set_recommended_min_free_kbytes); 
> > back in 4.1.14 and it made a huge difference. We aren't sure if the
> > issue is 100% fixed, but it could be. We will keep testing it.
> 
> It would be nice to have values of min_free_kbytes before and after
> set_recommended_min_free_kbytes() in your configuration.
> 

We'll try to get this for you. 

The reports are coming from 2GB Haswell chromebooks. I have a 4GB haswell 
chromebook and I cannot reproduce the issue, even if I boot the kernel with 
2GB or less.

After more testing, we were still able to reproduce the issue. It seems to 
have taken longer to show up this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
