Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 725606B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 18:28:36 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id va7so1917688obc.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 15:28:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130403221129.GL28522@linux.vnet.ibm.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
	<alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
	<alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
	<alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
	<20130403041447.GC4611@cmpxchg.org>
	<alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
	<20130403045814.GD4611@cmpxchg.org>
	<CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
	<20130403163348.GD28522@linux.vnet.ibm.com>
	<CAKOQZ8wd24AUCN2c6p9iLFeHMpJy=jRO2xoiKkH93k=+iYQpEA@mail.gmail.com>
	<20130403221129.GL28522@linux.vnet.ibm.com>
Date: Wed, 3 Apr 2013 15:28:35 -0700
Message-ID: <CAKOQZ8yFq5V1mZGrR_n7WqbgJ92WnpKO-ZvYY2n5Rn8+cjk0ew@mail.gmail.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
From: Ian Lance Taylor <iant@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

On Wed, Apr 3, 2013 at 3:11 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> How about a request for gcc to formally honor the current uses of volatile?

Seems harder to define, but, sure, if it can be made to work.

Ian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
