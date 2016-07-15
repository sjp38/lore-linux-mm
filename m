Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7746B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 04:23:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so9474684wma.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 01:23:50 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m22si3955232wmc.79.2016.07.15.01.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 01:23:48 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so1292032wme.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 01:23:48 -0700 (PDT)
Date: Fri, 15 Jul 2016 10:23:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160715082347.GC11811@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
 <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <20160714152913.GC12289@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com>
 <20160715072242.GB11811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160715072242.GB11811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Let me paste the patch with the full changelog and the explanation so
that we can reason about it more easily. If I am making some false
assumptions then please point them out.
--- 
