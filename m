Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx003.postini.com [74.125.246.103])
	by kanga.kvack.org (Postfix) with SMTP id 5FD076B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:21:16 -0400 (EDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOP00D7MVNEPH60@mailout1.samsung.com> for linux-mm@kvack.org;
 Fri, 21 Jun 2013 09:21:14 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
 <20130617131551.GA5018@dhcp22.suse.cz>
 <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
In-reply-to: <20130620121649.GB27196@dhcp22.suse.cz>
Subject: [PATCH v6] memcg: event control at vmpressure.
Date: Fri, 21 Jun 2013 09:21:13 +0900
Message-id: <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>

