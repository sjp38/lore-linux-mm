Message-ID: <460022B4.4000509@redhat.com>
Date: Tue, 20 Mar 2007 14:06:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #2
References: <45FF3052.0@redhat.com> <20070320183927.GI10084@localhost>
In-Reply-To: <20070320183927.GI10084@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Bob Picco wrote:

>> +	/*
>> + 	 *                 anon      recent_rotated_anon
>> +	 * %anon = 100 * --------- / ------------------- * IO cost
>> +	 *               anon+file   recent_scanned_anon
>> +	 */
>> +	anon_l = (anon_prio + 1) * (zone->recent_scanned_anon + 1);
>> +	do_div(anon_l, (zone->recent_rotated_anon + 1));
>> +
>> +	file_l = (file_prio + 1) * (zone->recent_scanned_file + 1);
>> +	do_div(file_l, (zone->recent_rotated_file + 1));
>> +
>> +	/* Normalize to percentages. */
>> +	*anon_percent = (unsigned long)100 * anon_l / (anon_l + file_l);
> I believe this requires a do_div on 32 bit arch. 

Actually, the "unsigned long long" is a holdover from the
code I had before.  With the calculation above, I think I
can make it a simple "unsigned long" and get rid of the
do_div magic alltogether...

Btw, it would help if you could trim your replies.  I almost
could not find your one line reply in-between the 1600 lines
of quoted text :)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
