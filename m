Content-Type: text/plain;
  charset="iso-8859-1"
From: Jordi Polo <mumismo@wanadoo.es>
Subject: Re: [PATCH] Prevent OOM from killing init
Date: Fri, 23 Mar 2001 00:10:29 +0100
References: <20010322124727.A5115@win.tue.nl> <Pine.LNX.4.21.0103221200410.21415-100000@imladris.rielhome.conectiva> <20010322200408.A5404@win.tue.nl>
In-Reply-To: <20010322200408.A5404@win.tue.nl>
MIME-Version: 1.0
Message-Id: <01032300102903.00452@mioooldpc>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Just a silly thing , think about a system with a process in charge of the 
security of the system, it avoid the script kiddies make funny things with 
it, log every etc. Now think this machine in an OOM situation, what will you 
prefer  trashing and an unusable machine or that oom kill , kills that really 
important process, the machines continues going on and the script kiddies 
make all the fun of it ?
I really think , killing that process is not the right thing and that we have:
1.- make some warnings to the apps, like malloc returning ENOMEM , 
2.- as long as trashing is almost never desired keep the oom kill code but 
make it more powerful allowing the sysadmin to control which pids will NEVER 
get killed even if that means trashing and system going down, we can make 
some pids default reliable like init or things like that but it could be 
changed for instance via /proc

--
Jordi Polo     
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
