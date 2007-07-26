Message-ID: <46A87EC7.6070002@gmail.com>
Date: Thu, 26 Jul 2007 13:00:23 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com> <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com> <46A81C39.4050009@gmail.com> <200707260839.51407.bhlope@mweb.co.za> <46A845BB.9080503@gmail.com> <20070726095829.GA26987@atjola.homenet>
In-Reply-To: <20070726095829.GA26987@atjola.homenet>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-15?Q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>, Rene Herman <rene.herman@gmail.com>, Bongani Hlope <bhlope@mweb.co.za>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/26/2007 11:58 AM, Bjorn Steinbrink wrote:

> Will now go and see what happens if I play with swappiness.

I in fact managed to overlook _all_ of swappiness (*) and was quite frankly 
under the impression that Linux would simply never swap anything out to make 
room for cache. Which is basic enough a misunderstanding that I'll go sulk 
in a corner now.

Rene.

(*)

$ grep -ri swappiness Documentation
$

Sigh...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
