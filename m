Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 271936B03A5
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:29:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g31so6523568wrg.15
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:29:48 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id j6si11736042wrj.264.2017.04.13.09.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 09:29:47 -0700 (PDT)
Date: Thu, 13 Apr 2017 18:29:46 +0200
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [RFC] Re: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20170413162946.jxyzfdggia2gge76@var.youpi.perso.aquilenet.fr>
References: <20160229162835.GA2816@var.bordeaux.inria.fr>
 <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(Ideally we'd be able to take the MAP_HUGETLB mmap flag into account to
map a single huge page repeatedly, even lowering the populating cost,
but AIUI of the current hugepage support it would be far from easy)

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
