Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E4A8B6B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 06:32:35 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Sm0PF-00025R-Lq
	for linux-mm@kvack.org; Tue, 03 Jul 2012 12:32:29 +0200
Received: from 117.57.172.73 ([117.57.172.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 12:32:29 +0200
Received: from xiyou.wangcong by 117.57.172.73 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 12:32:29 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 0/2 v4][rfc] tmpfs not interleaving properly
Date: Tue, 3 Jul 2012 10:32:18 +0000 (UTC)
Message-ID: <jsuhnh$h57$1@dough.gmane.org>
References: <20120702202635.GA20284@gulag1.americas.sgi.com>
 <4FF20A7C.7070801@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Mon, 02 Jul 2012 at 20:54 GMT, Nathan Zimmer <nzimmer@sgi.com> wrote:
>
> I apologize, it seems I have sent the patch before running checkpatch.
>

Yeah.. we don't use C++ style comments. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
