Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C39606B0002
	for <linux-mm@kvack.org>; Sat,  9 Feb 2013 00:25:33 -0500 (EST)
Received: by mail-vb0-f52.google.com with SMTP id fa15so2801052vbb.11
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 21:25:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <510632BD.3010702@parallels.com>
References: <510632BD.3010702@parallels.com>
Date: Fri, 8 Feb 2013 21:25:32 -0800
Message-ID: <CANN689FNsmFfHX6zqnefE9yzHBed1tXi6ppPzOkcxBZgCLYg2A@mail.gmail.com>
Subject: Re: [ATTEND][LSF/MM TOPIC] the memory controller
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On Mon, Jan 28, 2013 at 12:11 AM, Lord Glauber Costa of Sealand
<glommer@parallels.com> wrote:
> * memcg/global oom handling: I believe that the OOM killer could be
> significantly improved to allow for more deterministic killing of tasks,
> specially in containers scenarios where memcg is heavily deployed. In
> some situations, a group encompasses a whole service, and under
> pressure, it would be better to shut down the group altogether with all
> its tasks, while in others it would be better to keep the current
> behavior of shooting down a single task.

We at Google have some OOM wish-list as well:
- having an option to kill the entire cgroup when a contained task is
selected to die;
- recursive setting of OOM kill priorities in a cgroup hierarchy

I am frankly not the best person to talk about this; however if this
topic was selected I could plan for it and bring on a few notes :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
