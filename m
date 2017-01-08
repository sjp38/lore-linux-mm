Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1AC36B025E
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 19:07:57 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f4so40463153qte.1
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 16:07:57 -0800 (PST)
Received: from scorn.kernelslacker.org (scorn.kernelslacker.org. [2600:3c03::f03c:91ff:fe59:ec69])
        by mx.google.com with ESMTPS id m186si43542543qkc.45.2017.01.07.16.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Jan 2017 16:07:40 -0800 (PST)
Date: Sat, 7 Jan 2017 19:07:37 -0500
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 4.10-rc2 list_lru_isolate list corruption
Message-ID: <20170108000737.q3ukpnils5iifulg@codemonkey.org.uk>
References: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk>
 <20170106165941.GA19083@cmpxchg.org>
 <20170106195851.7pjpnn5w2bjasc7w@codemonkey.org.uk>
 <20170107011931.GA9698@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170107011931.GA9698@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Fri, Jan 06, 2017 at 08:19:31PM -0500, Johannes Weiner wrote:

 > Argh, __radix_tree_delete_node() makes the flawed assumption that only
 > the immediate branch it's mucking with can collapse. But this warning
 > points out that a sibling branch can collapse too, including its leaf.
 > 
 > Can you try if this patch fixes the problem?

18 hours and still running.. I think we can call it good.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
