Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BC9356B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:38:56 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 123so59766101wmz.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:38:56 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id cj3si18993895wjc.46.2016.01.25.02.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 02:38:55 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id 123so59765589wmz.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:38:55 -0800 (PST)
Date: Mon, 25 Jan 2016 12:38:53 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Message-ID: <20160125103853.GD11095@node.shutemov.name>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com>
 <20160121161656.GA16564@node.shutemov.name>
 <loom.20160123T165232-709@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <loom.20160123T165232-709@post.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Greenberg <hugh@galliumos.org>
Cc: linux-mm@kvack.org

On Sat, Jan 23, 2016 at 03:57:21PM +0000, Hugh Greenberg wrote:
> Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> > 
> > Could you try to insert "late_initcall(set_recommended_min_free_kbytes);"
> > back and check if makes any difference.
> > 
> 
> We tested adding late_initcall(set_recommended_min_free_kbytes); 
> back in 4.1.14 and it made a huge difference. We aren't sure if the
> issue is 100% fixed, but it could be. We will keep testing it.

It would be nice to have values of min_free_kbytes before and after
set_recommended_min_free_kbytes() in your configuration.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
