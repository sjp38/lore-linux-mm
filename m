Date: Tue, 23 Jul 2002 15:45:42 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: disable highpte in rmap kernels
Message-ID: <61060000.1027464342@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

highpte doesn't work with rmap at the moment, and causes users
to get panics that aren't trivially obvious what is causing them.
I vote we disable it until it works .... totally untested patch below ...
does this look sane to people? Seems trivial enough that even I
couldn't get it wrong, but .... ;-)

M.

--- virgin-2.5.27/arch/i386/config.in	Sat Jul 20 12:11:12 2002
+++ linux-2.5.27-nohighpte/arch/i386/config.in	Tue Jul 23 13:54:43 2002
@@ -185,10 +185,6 @@
 	 4GB           CONFIG_HIGHMEM4G \
 	 64GB          CONFIG_HIGHMEM64G" off
 
-if [ "$CONFIG_HIGHMEM4G" = "y" -o "$CONFIG_HIGHMEM64G" = "y" ]; then
-   bool 'Use high memory pte support' CONFIG_HIGHPTE
-fi
-
 if [ "$CONFIG_HIGHMEM4G" = "y" ]; then
    define_bool CONFIG_HIGHMEM y
 fi
--- virgin-2.5.27/arch/ppc/config.in	Sat Jul 20 12:11:04 2002
+++ linux-2.5.27-nohighpte/arch/ppc/config.in	Tue Jul 23 15:40:19 2002
@@ -263,7 +263,6 @@
 comment 'General setup'
 
 bool 'High memory support' CONFIG_HIGHMEM
-dep_bool '  Support for PTEs in high memory' CONFIG_HIGHPTE $CONFIG_HIGHMEM
 bool 'Prompt for advanced kernel configuration options' CONFIG_ADVANCED_OPTIONS
 if [ "$CONFIG_ADVANCED_OPTIONS" = "y" ]; then
    if [ "$CONFIG_HIGHMEM" = "y" ]; then

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
