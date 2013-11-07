Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B9E186B0154
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 07:27:08 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id x10so535452pdj.9
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 04:27:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id d2si2835121pac.213.2013.11.07.04.27.05
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 04:27:06 -0800 (PST)
Date: Thu, 7 Nov 2013 10:26:58 -0200
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] mm: add strictlimit knob -v2
Message-ID: <20131107122658.GA3355@khazad-dum.debian.net>
References: <20131104140104.7936d263258a7a6753eb325e@linux-foundation.org>
 <20131106150515.25906.55017.stgit@dhcp-10-30-17-2.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131106150515.25906.55017.stgit@dhcp-10-30-17-2.sw.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: akpm@linux-foundation.org, karl.kiniger@med.ge.com, tytso@mit.edu, linux-kernel@vger.kernel.org, t.artem@lycos.com, linux-mm@kvack.org, mgorman@suse.de, jack@suse.cz, fengguang.wu@intel.com, torvalds@linux-foundation.org

Is there a reason to not enforce strictlimit by default?

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
