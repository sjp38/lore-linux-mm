Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id DC56E6B0072
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 20:51:43 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5977109pad.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 17:51:43 -0800 (PST)
Date: Tue, 13 Nov 2012 17:51:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I
 think)
In-Reply-To: <20121114012234.GB8152@offline.be>
Message-ID: <alpine.DEB.2.00.1211131750200.408@chino.kir.corp.google.com>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com> <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com> <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com> <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
 <CALCETrXSzNEdNEZaQqB93rpP9zXcBD4KRX_bjTAnzU6JEXcApg@mail.gmail.com> <alpine.DEB.2.00.1211131553170.17623@chino.kir.corp.google.com> <20121114012234.GB8152@offline.be>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Duponcheel <marc@offline.be>
Cc: Andy Lutomirski <luto@amacapital.net>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 Nov 2012, Marc Duponcheel wrote:

>  Hi all, please let me know if there is are patches you want me to try.
> 
>  FWIW time did not stand still and I run 3.6.6 now.
> 

Hmm, interesting since there are no core VM changes between 3.6.2, the 
kernel you ran into problems with, and 3.6.6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
